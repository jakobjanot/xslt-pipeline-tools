FROM openjdk:8-jre

ENV XSPEC_VERSION=2.2.4
ENV SAXON_VERSION=12.1

# install XSpec
RUN curl -fsSL -o xspec-${XSPEC_VERSION}.tar.gz https://github.com/xspec/xspec/archive/v${XSPEC_VERSION}.tar.gz && \
	tar xzf xspec-${XSPEC_VERSION}.tar.gz && \
	mv /xspec-${XSPEC_VERSION} /xspec && \
	rm xspec-${XSPEC_VERSION}.tar.gz
ENV XSPEC_HOME /xspec

WORKDIR /xspec
	
# install Saxon HE
RUN mkdir -p saxon && \
	export SAXON_CP=/xspec/saxon/saxon9he.jar && \
	curl -fsSL -o ${SAXON_CP} https://repo.maven.apache.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar && \
	chmod +x ${SAXON_CP}
ENV SAXON_CP /xspec/saxon/saxon9he.jar 

# use non-privileged user to run xspec
RUN groupadd -r xspec && \
    useradd -s /bin/bash -r -g xspec xspec && \
 	chown xspec:xspec -R /xspec
USER xspec

# copy test files
COPY test /test

# copy entrypoint script
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
