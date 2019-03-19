##############################################################################
# meteor-dev stage - builds image for dev and used with docker-compose.yml
##############################################################################
FROM quay.io/spivegin/meteor:latest as meteor-dev

LABEL maintainer="The Legion Marker <architecture@legionmarket.com>"

ENV PATH $PATH:/root/.meteor:$APP_SOURCE_DIR/node_modules/.bin

# Because Docker Compose uses a named volume for node_modules and named volumes are owned
# by root by default, we have to initially create node_modules here with correct owner.
# Without this NPM cannot write packages into node_modules later, when running in a container.

RUN git clone https://github.com/reactioncommerce/reaction.git . &&\
    mkdir node_modules &&\
    meteor npm install 



##############################################################################
# builder stage - builds the production bundle
##############################################################################
FROM meteor-dev as builder

RUN printf "\\n[-] Running Reaction plugin loader...\\n" \
    && reaction plugins load
RUN printf "\\n[-] Building Meteor application...\\n" \
    && meteor build --server-only --architecture os.linux.x86_64 --directory "$APP_BUNDLE_DIR"

WORKDIR $APP_BUNDLE_DIR/bundle/programs/server/

RUN meteor npm install --production


# ##############################################################################
# # final build stage - create the final production image
# ##############################################################################
# FROM quay.io/spivegin/nodejsyarn

# # Default environment variables
# ENV ROOT_URL "http://localhost"
# ENV PORT 3000

# # grab the dependencies and built app from the previous builder image
# COPY --from=builder /opt/reaction/dist/bundle /opt/tlm/app

# WORKDIR /opt/tlm/app

# EXPOSE 3000

# CMD ["node", "main.js"]


# FROM quay.io/spivegin/tlmbasedebian

