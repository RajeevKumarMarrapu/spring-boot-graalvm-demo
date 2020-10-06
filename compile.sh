#!/usr/bin/env bash

echo "[-->] Detect artifactId from pom.xml"
ARTIFACT=demo
echo "artifactId is '$ARTIFACT'"

echo "[-->] Detect artifact version from pom.xml"
VERSION=0.0.1-SNAPSHOT
echo "artifact version is '$VERSION'"

echo "[-->] Detect Spring Boot Main class ('start-class') from pom.xml"
MAINCLASS=com.example.demo.DemoApplication
echo "Spring Boot Main class ('start-class') is '$MAINCLASS'"

echo "[-->] Cleaning target directory & creating new one"
rm -rf target
mkdir -p target/native-image

echo "[-->] Build Spring Boot App with mvn package"
mvn -DskipTests package

echo "[-->] Expanding the Spring Boot fat jar"
JAR="$ARTIFACT-$VERSION.jar"
cd target/native-image
jar -xvf ../$JAR >/dev/null 2>&1
cp -R META-INF BOOT-INF/classes

echo "[-->] Set the classpath to the contents of the fat jar (where the libs contain the Spring Graal AutomaticFeature)"
LIBPATH=`find BOOT-INF/lib | tr '\n' ':'`
CP=BOOT-INF/classes:$LIBPATH

GRAALVM_VERSION=`native-image --version`
echo "[-->] Compiling Spring Boot App '$ARTIFACT' with $GRAALVM_VERSION"
time native-image --no-server -J-Xmx6G --no-fallback -H:Name=$ARTIFACT -Dspring.spel.ignore=true -Dspring.graal.remove-unused-autoconfig=true -Dspring.graal.remove-yaml-support=true --static -cp $CP $MAINCLASS;