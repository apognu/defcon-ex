<template lang="pug">
  div
    router-link(to="/checks/new" class="float-right btn btn-secondary") New check

    h2 Checks

    Loading(:until="data !== undefined")
      div(v-if="data")
        form.form-inline.form-filters
          .form-group.col-4.offset-4
            input.form-control(type="text" placeholder="Search for a check..." autofocus="autofocus" v-model="filters.title" @keyup="getDebouncedChecks")
          .form-group.col-4
            select.custom-select(v-model="filters.group" @change="getDebouncedChecks")
              option(value="") All groups...
              option(v-for="group in data.groups" :value="group.id") {{group.title}}

        .block
          table.table
            thead.thead-light
              tr
                th
                th.fill Check name
                th Type
                th Last/next run
                th.fit

            tbody
              tr(v-for="check in data.checks" :class="{ 'enabled-false': !check.enabled, 'table-danger': !status(check) }")
                td
                  .status
                    .led.status-operational(v-if="status(check)")
                    .led.status-outages(v-else)
                td
                  router-link(:to="{ name: 'check', params: { id: check.uuid } }"): b {{check.title}}
                  template(v-if="check.group")
                    br
                    | {{check.group.title}}
                td: code.check-type {{check.kind}}
                td: p
                  b {{last_check(check)}}
                  br
                  small {{next_check(check)}}
                td.actions
                  router-link(:to="{ name: 'checks.edit', params: { id: check.uuid } }" class="btn btn-secondary btn-sm mr-1") Edit
                  a.btn.btn-danger.btn-sm(href="#" @click.prevent="deleteCheck(check)") Delete
</template>

<script>
import axios from 'axios';
import Misc from '@/misc';
import Loading from '@/components/misc/Loading';

export default {
  components: { Loading },

  data: () => ({
    interval: null,
    debounced: null,
    data: undefined,
    filters: {
      title: '',
      group: ''
    }
  }),

  async mounted() {
    this.getChecks();
    this.interval = setInterval(this.getChecks, 10000);
  },

  destroyed() {
    clearInterval(this.interval);
  },

  methods: {
    getDebouncedChecks() {
      if (this.debounced !== null) {
        return this.debounced();
      }

      this.debounced = _.debounce(this.getChecks, 500, { leading: true });
    },

    getChecks() {
      let query = {};
      if (this.filters.title != '') query['filter_check_title'] = this.filters.title;
      if (this.filters.group != '') query['filter_group_id'] = this.filters.group;

      axios
        .get('/api/checks', { params: query })
        .then(response => this.data = response.data);
    },

    deleteCheck(check) {
      axios
        .delete(`/api/checks/${check.uuid}`)
        .then(_ => this.getChecks());
    },

    status: (check) => check.outages.length === 0,

    last_check: (check) => {
      if (check.events.length === 0) return 'N/A';
      else {
        return Misc.formatDate(new Date(check.events[0].inserted_at));
      }
    },

    next_check: (check) => {
      const base = (check.events.length === 0)
        ? null
        : Date.parse(check.events[0].inserted_at);

      if (base === null) return 'N/A';
      else return Misc.formatDate(new Date(base + check.interval));
    },
  }
};
</script>
