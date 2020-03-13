<template lang="pug">
  div
    h3 {{title}}

    .uptime-graph(:class="type")
      tippy(v-for="([bucket, count], _) in data" :key="bucket" arrow :content="formatDate(bucket)")
        template(v-slot:trigger)
          div(:class="{ status: true, 'status-operational': count == 0, 'status-outages': count > 0 }" @click="inspect(bucket)")
</template>

<script>
import Misc from '@/misc';

export default {
  props: {
    type: {
      type: String,
      default: 'squares',
    },
    title: {
      type: String,
      default: '',
    },
    data: {
      type: Array,
      default: () => [],
    },
    dateStyle: {
      type: String,
      default: 'full',
    },
    range: {
      type: String,
      default: 'hour',
    },
  },

  methods: {
    formatDate(date) {
      return Misc.formatCustomDate(new Date(date), this.dateStyle);
    },

    inspect(date) {
      const from = Math.floor(new Date(date).getTime() / 1000);

      this.$router.push({
        name: 'outages.range',
        params: { from: from, range: this.range },
      });
    },
  },
};
</script>

<style lang="scss">
.uptime-graph {
  display: flex;
  flex-direction: row;

  > span > span:nth-child(2) {
    display: none;
  }

  &.squares {
    span {
      display: flex;
      flex: 1;
    }

    &.b-12 div {
      width: 100%;
    }

    &.b-7 div {
      width: 100%;
    }

    div {
      display: inline-block;
      margin: 0 2px;
    }
  }

  &.pills {
    span {
      display: flex;
      flex: 1;
    }

    div {
      width: 100%;
      margin: 0 1px;
      border-radius: 20px;

      @media only screen and (max-width: 768px) {
        margin: 0;
        border-radius: 0;
      }
    }

    @media only screen and (max-width: 768px) {
      border-radius: 4px;
      overflow: hidden;
    }
  }

  div {
    cursor: pointer;

    &.status {
      height: 50px;
    }

    &.status-operational {
      background: map-get($theme-colors, 'success');
    }

    &.status-outages {
      background: map-get($theme-colors, 'danger');
    }
  }
}
</style>
