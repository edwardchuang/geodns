FROM golang:alpine
RUN apk add --no-cache --virtual .build-deps \
	geoip \
	geoip-dev \
	git \
	wget \
	pkgconfig \
	gcc \
	musl-dev \
	openssl
RUN cd /usr/share/GeoIP \
 && rm -f * \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
 && wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz \
 && gzip -d GeoIP.dat.gz \
 && gzip -d GeoLiteCity.dat.gz \
 && gzip -d GeoIPASNum.dat.gz \
 && mv GeoLiteCity.dat GeoIPCity.dat
WORKDIR /go
RUN go get github.com/abh/geodns
WORKDIR /go/src/github.com/abh/geodns
RUN go test
RUN go build
EXPOSE 5053
EXPOSE 5053/udp
EXPOSE 8053
RUN mkdir /conf
COPY conf/ /conf/
CMD geodns -interface 0.0.0.0 -port 5053 -config="/conf/"
