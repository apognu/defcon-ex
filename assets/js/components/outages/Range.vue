<template lang="pug">
  div
    h2 Outages history

    Loading(:until="outages !== undefined")
      Status(v-if="outages" :outages="outages.length")
        .block
          table.table
            thead.thead-light
              tr
                th
                th Check title
                th.fill Message
                th Started on
                th Ended on

            tbody
              tr(v-for="outage in outages")
                td
                  .status(v-if="outage.ended_on"): span.led.status-operational
                  .status(v-else): span.led.status-outages
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
                td {{formatDate(outage.ended_on)}}
</template>

<script>
import axios from 'axios';
import Misc from '@/misc';
import Loading from '@/components/misc/Loading';
import Status from '@/components/misc/Status';

export default {
  components: { Loading, Status },

  data: () => ({
    outages: undefined
  }),

  async mounted() {
    axios
      .get(`/api/outages/range/${this.$route.params.from}/${this.$route.params.range}`)
      .then(response => this.outages = response.data);
  },

  methods: {
    formatDate(date) {
      if (date == null) return '-';

      return Misc.formatCustomDate(new Date(date), this.dateStyle);
    }
  }
};
</script>
