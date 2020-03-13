<template lang="pug">
  .block
    input(type="hidden" v-model="$parent.data.check.play_store_spec.id")

    .row: .col: h3 Google Play Store

    .row
      .col
        .form-group
          label(for="app_id") App ID
          input#app_id.form-control(type="text" v-model="$parent.data.check.play_store_spec.app_id")
</template>
