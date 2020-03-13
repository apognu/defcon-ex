<template lang="pug">
  .block
    input(type="hidden" v-model="$parent.data.check.tls_spec.id")

    .row: .col: h3 Certificates expiration

    .row
      .col
        .form-group
          label(for="domain") Domains
          input#domain.form-control(type="text" v-model="$parent.data.check.tls_spec.domain")
          small.form-text.text-muted Several domains can be specified by separating them with a comma

      .col
        .form-group
          label(for="window") Expiration window (in days)
          input#window.form-control(type="number" v-model="$parent.data.check.tls_spec.window")
          small.form-text.text-muted Certificates expiring within this window will trigger an alert
</template>
