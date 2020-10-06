# Simple Dockerfile adding Maven and GraalVM Native Image compiler to the standard
# https://hub.docker.com/r/oracle/graalvm-ce image
FROM oracle/graalvm-ce:20.2.0-java11

ADD . /build
WORKDIR /build

# For SDKMAN to work we need unzip & zip
RUN yum install -y unzip zip

# For --static compilation
RUN yum install gcc glibc-devel zlib-devel libstdc++-static

RUN \
    # Install SDKMAN
    curl -s "https://get.sdkman.io" | bash; \
    source "$HOME/.sdkman/bin/sdkman-init.sh"; \
    sdk install maven; \
    # Install GraalVM Native Image
    gu install native-image;

RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && mvn --version

RUN native-image --version

RUN chmod +x ./compile.sh
RUN chmod +x ./heroku-release.sh

RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && ./compile.sh


# We use a Docker multi-stage build here in order that we only take the compiled native Spring Boot App from the first build container
FROM alpine

MAINTAINER rajeevmarrapu

# Add Spring Boot Native app spring-boot-graal to Container
COPY --from=0 "/build/target/native-image/demo" demo

# Fire up our Spring Boot Native app by default
CMD [ "./demo" ]