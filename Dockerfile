FROM fluent/fluentd:v1.16-1

USER root
RUN gem install fluent-plugin-loki

USER fluent

