<template lang="pug">
  div
    h3 Edit alerter

    .block(@keyup.enter="saveAlerter")
      .row
        .col
          .form-group
            label(for="title") Alerter title
            input.form-control(type="text" v-model="alerter.title")

      .row
        .col
          .form-group
            label(for="api_key") API key
            input.form-control(type="text" v-model="alerter.api_key")

        .col
          .form-group
            label(for="channel") Channel
            input.form-control(type="text" v-model="alerter.channel")

    .form-group.text-right
      button.btn.btn-primary(@click="saveAlerter") Save alerter
</template>

<script>
import axios from 'axios';

export default {
  data: () => ({
    alerter: {},
  }),

  async mounted() {
    if (!this.$route.meta.new) {
      axios
        .get(`/api/alerters/${this.$route.params.id}`)
        .then(response => {
          this.alerter = response.data;
          this.title = this.alerter.title;
          this.api_key = this.alerter.api_key;
          this.channel = this.alerter.channel;
        });
    }
  },

  methods: {
    saveAlerter() {
      const body = {
        alerter: {
          title: this.alerter.title,
          api_key: this.alerter.api_key,
          channel: this.alerter.channel,
        }
      };

      if (this.$route.meta.new) {
        axios
          .post('/api/alerters', body)
          .then(_ => this.$router.push({ name: 'alerters' }));
      } else {
        axios
          .put(`/api/alerters/${this.alerter.uuid}`, body)
          .then(_ => this.$router.push({ name: 'alerters' }));
      }
    }
  }
};
</script>
