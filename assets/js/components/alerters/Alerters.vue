<template lang="pug">
  div
    router-link(to="/alerters/new" class="float-right btn btn-secondary") New alerter

    h2 Alerters

    Loading(:until="alerters !== undefined")
      .block(v-if="alerters")
        table.table
          thead.thead-light
            tr
              th.fill Alerter name
              th Channel
              th.fit

          tbody
            tr(v-for="alerter in alerters")
              td {{alerter.title}}
              td {{alerter.channel}}
              td.actions
                router-link(:to="{ name: 'alerters.edit', params: { id: alerter.uuid } }" class="btn btn-secondary btn-sm mr-1") Edit
                a.btn.btn-danger.btn-sm(href="#" @click.prevent="deleteAlerter(alerter)") Delete
</template>

<script>
import axios from 'axios';
import Loading from '@/components/misc/Loading';

export default {
  components: { Loading },

  data: () =>({
    alerters: undefined
  }),

  async mounted() {
    this.getAlerters();
  },

  methods: {
    getAlerters() {
      axios
        .get('/api/alerters')
        .then(response => {
          this.alerters = response.data;
        });
    },

    deleteAlerter(alerter) {
      axios
        .delete(`/api/alerters/${alerter.uuid}`)
        .then(_ => this.getAlerters());
    }
  }
};
</script>
