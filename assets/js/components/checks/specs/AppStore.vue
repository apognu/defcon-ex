<template lang="pug">
  .block
    input(type="hidden" v-model="$parent.data.check.app_store_spec.id")

    .row: .col: h3 Apple AppStore

    .row
      .col
        .form-group
          label(for="bundle_id") Bundle ID
          input#bundle_id.form-control(type="text" v-model="$parent.data.check.app_store_spec.bundle_id")
</template>
