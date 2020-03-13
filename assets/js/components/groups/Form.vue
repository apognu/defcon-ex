<template lang="pug">
  div
    h2 Edit group

    div(@keyup.enter="saveGroup")
      .row
        .col
          .form-group
            label(for="title") Group title
            input#title.form-control(type="text" v-model="group.title")

      .form-group.text-right
        button.btn.btn-primary(@click="saveGroup") Save group
</template>

<script>
import axios from 'axios';

export default {
  data: () => ({
    group: {},
  }),

  async mounted() {
    if (!this.$route.meta.new) {
      axios
        .get(`/api/groups/${this.$route.params.id}`)
        .then(response => {
          this.group = response.data;
        });
    }
  },

  methods: {
    saveGroup() {
      const body = {
        group: {
          title: this.group.title
        }
      };

      if (this.$route.meta.new) {
        axios
          .post('/api/groups', body)
          .then(_ => this.$router.push({ name: 'groups' }));
      } else {
        axios
          .put(`/api/groups/${this.group.uuid}`, body)
          .then(_ => this.$router.push({ name: 'groups' }));
      }
    }
  }
};
</script>
