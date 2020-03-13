<template lang="pug">
  .block
    input(type="hidden" v-model="$parent.data.check.crt_spec.id")

    .row: .col: h3 Certificates issuance

    .row
      .col
        .form-group
          label(for="domain") Domain
          input#domain.form-control(type="text" v-model="$parent.data.check.crt_spec.domain")
          small.form-text.text-muted Only one domain name, specify wildcard as "%.domain.tld"
</template>
