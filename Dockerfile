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
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz \
 && wget -N -nv -O GeoLite2-ASN.mmdb.gz 'https://updates.maxmind.com/app/update_secure?edition_id=GeoLite2-ASN' \
 && gzip -d GeoLite2-ASN.mmdb.gz \
 && gzip -d GeoLite2-City.mmdb.gz \
 && gzip -d GeoLite2-Country.mmdb.gz
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
