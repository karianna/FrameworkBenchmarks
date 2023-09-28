FROM maven:3.9.4-eclipse-temurin-11 as maven
WORKDIR /netty
COPY pom.xml pom.xml
COPY src src
RUN mvn compile assembly:single -q

FROM eclipse-temurin:11.0.20.1_1-jdk
WORKDIR /netty
COPY --from=maven /netty/target/netty-example-0.2.0-SNAPSHOT-jar-with-dependencies.jar app.jar

EXPOSE 8080

CMD ["java", "-server", "-XX:+UseNUMA", "-XX:+UseParallelGC", "-XX:+AggressiveOpts", "-Dio.netty.buffer.checkBounds=false", "-Dio.netty.buffer.checkAccessible=false", "-Dio.netty.iouring.iosqeAsyncThreshold=32000", "-jar", "app.jar"]
