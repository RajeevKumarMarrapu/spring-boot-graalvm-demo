@echo off

SET ARTIFACT=demo
SET VERSION=0.0.1-SNAPSHOT
SET MAINCLASS=com.example.demo.DemoApplication

echo "artifactId is '%ARTIFACT%'"
echo "artifact version is '%VERSION%'"
echo "Spring Boot Main class is '%MAINCLASS%'"

echo "[-->] Cleaning target directory & creating new one"
RMDIR /s /q target
MKDIR target\native-image

echo "[-->] Build Spring Boot App with mvn package"
call mvn -q -DskipTests package

echo "[-->] Expanding the Spring Boot fat jar"
SET JAR="%ARTIFACT%-%VERSION%.jar"
cd target/native-image
jar -xvf ../%JAR% >/dev/null 2>&1
COPY  META-INF BOOT-INF\classes

echo "[-->] Set the classpath to the contents of the fat jar (where the libs contain the Spring Graal AutomaticFeature)"
SET LIBPATH=BOOT-INF\classes;BOOT-INF\lib\*
SET CP="BOOT-INF\classes;%LIBPATH%"

echo "[-->] Compiling Spring Boot App '%ARTIFACT%'"
native-image --static --no-server -J-Xmx5G --no-fallback -H:Name=%ARTIFACT% -Dspring.spel.ignore=true -Dspring.graal.remove-unused-autoconfig=true -Dspring.graal.remove-yaml-support=true -cp %CP% %MAINCLASS%
