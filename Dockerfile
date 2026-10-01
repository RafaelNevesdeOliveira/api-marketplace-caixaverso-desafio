# syntax=docker/dockerfile:1.7

# A primeira etapa compila o projeto com a mesma versão homologada do Java.
FROM maven:3.9.11-eclipse-temurin-25 AS build
WORKDIR /workspace

# Copiar o pom antes permite reaproveitar o cache das dependências.
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -B dependency:go-offline

COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B clean package

# A imagem final contém somente o Java necessário para executar a API.
FROM eclipse-temurin:25-jre
WORKDIR /app

RUN groupadd --system spring && useradd --system --gid spring spring
COPY --from=build --chown=spring:spring /workspace/target/marketplace-desafio-api-1.0.0.jar app.jar

USER spring:spring
EXPOSE 8082

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
