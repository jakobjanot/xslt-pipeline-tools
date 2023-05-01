FROM openjdk:8-jre

ENV XSPEC_HOME /lib/xspec/xspec-2.2.4
ENV SAXON_CP /lib/saxon/Saxon-HE-10.8.jar 

WORKDIR /
COPY /lib /lib

# copy entrypoint script
COPY /bin/xspec /entrypoint.sh

VOLUME [ "/xspec" ]
VOLUME [ "/xslt" ]

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD [ "/xspec" ]
