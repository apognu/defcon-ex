<template lang="pug">
  .block
    input(type="hidden" v-model="$parent.data.check.http_spec.id")

    .row: .col: h3 HTTP request

    .row
      .col
        .form-group
          label(for="url") URL
          input#url.form-control(type="text" v-model="$parent.data.check.http_spec.url")

    .row
      .col
        .form-group
          label(for="expected_code") Expected status code
          input#expected_code.form-control(type="number" v-model="$parent.data.check.http_spec.expected_code")

      .col
        .form-group
          label(for="expected_content") Expected content
          input#expected_content.form-control(type="text" v-model="$parent.data.check.http_spec.expected_content")
</template>
