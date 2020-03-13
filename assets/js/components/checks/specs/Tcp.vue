<template lang="pug">
  .block
    input(type="hidden" v-model="$parent.data.check.tcp_spec.id")

    .row: .col: h3 TCP port

    .row
      .col
        .form-group
          label(for="host") Host
          input#host.form-control(type="text" v-model="$parent.data.check.tcp_spec.host")

      .col
        .form-group
          label(for="port") Port
          input#port.form-control(type="number" v-model="$parent.data.check.tcp_spec.port")
</template>
