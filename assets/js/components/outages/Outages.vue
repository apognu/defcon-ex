<template lang="pug">
  div
    router-link(to="/outages/history" class="float-right btn btn-secondary") History

    Loading(:until="outages !== undefined")
      Status(v-if="outages" :outages="outages.length")
        h2 Outages

        .block
          table.table
            thead.thead-light
              tr
                th
                th Check title
                th.fill Message
                th Started on
                th Last run

            tbody
              tr(v-for="outage in outages")
                td: .status: span.led.status-outages
                td
                  router-link(:to="{ name: 'check', params: { id: outage.check.uuid } }"): b {{outage.check.title}}
                  template(v-if="outage.check.group")
                    br
                    | {{outage.check.group.title}}
                td.wrap
                  template(v-if="outage.check.ignore")
                    .badge.badge-secondary Muted
                    br
                  | {{outage.event.message}}
                td {{formatDate(outage.started_on)}}
                td {{formatDate(outage.event.inserted_at)}}
</template>

<script>
import _ from 'lodash';
import axios from 'axios';
import Misc from '@/misc';
import Loading from '@/components/misc/Loading';
import Status from '@/components/misc/Status';

export default {
  components: { Loading, Status },

  data: () => ({
    outages: undefined,
  }),

  async mounted() {
    this.getOutages();
    setInterval(this.getOutages, 10000);
  },

  destroyed() {
    clearInterval(this.interval);
  },

  methods: {
    getOutages() {
      axios
        .get('/api/outages')
        .then(
          (response) =>
            (this.outages = _.filter(
              response.data,
              (outage) => !outage.check.ignore,
            )),
        );
    },

    formatDate(date) {
      return Misc.formatCustomDate(new Date(date), this.dateStyle);
    },
  },
};
</script>
