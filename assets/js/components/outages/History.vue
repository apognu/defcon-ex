<template lang="pug">
  div
    h2 Outage history

    Loading(:until="outages !== undefined")
      .block(v-if="outages")
        table.table
          thead.thead-light
            tr
              th
              th Check title
              th.fill.hidden-sm-down Message
              th Started on
              th.hidden-sm-down Ended on

          tbody
            tr(v-for="outage in outages")
              td
                .status(v-if="outage.ended_on"): span.led.status-operational
                .status(v-else): span.led.status-outages
              td.hidden-sm-down
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
              td.hidden-sm-down {{formatDate(outage.ended_on)}}
</template>

<script>
import _ from 'lodash';
import axios from 'axios';
import Misc from '@/misc';
import Loading from '@/components/misc/Loading';

export default {
  components: { Loading },

  data: () => ({
    interval: null,
    outages: undefined,
  }),

  async mounted() {
    this.getOutages();
    setInterval(this.getOutages, 10000);
  },

  destroy() {
    clearInterval(this.interval);
  },

  methods: {
    getOutages() {
      this.interval = axios
        .get('/api/outages/history')
        .then(
          (response) =>
            (this.outages = _.filter(
              response.data,
              (outage) => !outage.check.ignore,
            )),
        );
    },

    formatDate(date) {
      if (date == null) return '-';

      return Misc.formatCustomDate(new Date(date), this.dateStyle);
    },
  },
};
</script>
