<template lang="pug">
  Loading(:until="data !== undefined")
    div(v-if="data")
      router-link(:to="{ name: 'checks.edit', params: { id: data.check.uuid } }" class="float-right btn btn-secondary") Edit

      h2
        span.group_title(v-if="data.check.group") {{data.check.group.title}}
        span.group_title(v-else) Ungrouped
        | {{" / "}}
        | {{data.check.title}}

      Status(:outages="data.outages === null ? 0 : 1")

      div(v-if="!data.check.ignore")
        .block.pb
          .row
            .col-md-6.text-center
              h3 Hourly uptime for last 30 days
              span.figure {{rate(data.stats_30d)}}

            .col-md-6.text-center
              h3 Daily uptime for last 7 days
              span.figure {{rate(data.stats_1w)}}

        .block.pb
          .row
            .col-md-4
              Graph(title="Last week" type="squares b-7" :data="data.stats_1w")

            .col-md-8.uptime-graph-pill-container
              Graph(title="Last 72 hours" type="pills" :data="data.stats_72h")
      .alert.alert-info.mb-5(v-else) This check does not count toward uptime calculations. Statistics cannot be shown.


      .block
        table.table
          thead.thead-light
            tr
              th Event date
              th Status
              th.fill Message

          tbody
            tr(v-for="event in data.check.events.slice(0, 30)")
              td {{formatDate(event.inserted_at)}}
              td
                .span.badge.badge-success(v-if="event.status === 0") Success
                .span.badge.badge-danger(v-else) Critical
              td.ellipsis: span {{event.message}}
</template>

<script>
import axios from 'axios';
import Misc from '@/misc';
import Loading from '@/components/misc/Loading';
import Status from '@/components/misc/Status';
import Graph from '@/components/dashboard/Graph';

export default {
  components: { Loading, Status, Graph },

  data: () => ({
    data: undefined,
  }),

  async mounted() {
    axios
      .get(`/api/checks/${this.$route.params.id}`)
      .then((response) => (this.data = response.data));
  },

  methods: {
    rate(buckets) {
      if (buckets === undefined) return 'N/A';

      let result = _.groupBy(buckets, ([_, outages]) => outages > 0);
      result = _.mapValues(result, (outages) => outages.length);
      result[true] = result[true] || 0;

      let rate = Math.trunc(100 - (result[true] / result[false]) * 100);

      return `${rate} %`;
    },

    formatDate: (date) => Misc.formatDate(new Date(date)),
  },
};
</script>

<style scoped lang="scss">
.figure {
  font-size: 3em;
  color: #343434;
}

.group_title {
  color: #525252;
}
</style>
