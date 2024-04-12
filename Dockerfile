FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/IdoBouskila/Pokedex.git && \
    cd Pokedex && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG}) && \
    rm -rf .git && \
    sed -i 's/const base/let base/' src/utils/api-fetch.js && \
    PATCH="\
    try {\n\
        const request = new XMLHttpRequest();\n\
        request.open('GET', '/base.txt', false);\n\
        request.send();\n\
        if (request.status === 200) {\n\
            base = request.responseText;\n\
        }\n\
    } catch (e) {\n\
        console.error(e);\n\
    }\
    " && \
    sed -i "/export const apiFetch/i$PATCH" src/utils/api-fetch.js

FROM node:alpine AS build

WORKDIR /Pokedex
COPY --from=base /git/Pokedex .
RUN npm install && \
    npm run build

FROM lipanski/docker-static-website

COPY --from=build /Pokedex/dist .
