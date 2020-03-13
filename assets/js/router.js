import Vue from 'vue';
import VueRouter from 'vue-router';

import Dashboard from '@/components/dashboard/Dashboard';
import Outages from '@/components/outages/Outages';
import OutageHistory from '@/components/outages/History';
import OutageRange from '@/components/outages/Range';

import Groups from '@/components/groups/Groups';
import GroupForm from '@/components/groups/Form';

import Alerters from '@/components/alerters/Alerters';
import AlerterForm from '@/components/alerters/Form';

import Check from '@/components/checks/Check';
import Checks from '@/components/checks/Checks';
import CheckForm from '@/components/checks/Form';

Vue.use(VueRouter);

const routes = [
  { name: 'dashboard', path: '/', component: Dashboard },
  { name: 'outages', path: '/outages', component: Outages },
  { name: 'outages.history', path: '/outages/history', component: OutageHistory },
  { name: 'outages.range', path: '/outages/range/:from/:range', component: OutageRange },

  { name: 'groups', path: '/groups', component: Groups },
  { name: 'groups.new', path: '/groups/new', component: GroupForm, meta: { new: true } },
  { name: 'groups.edit', path: '/groups/:id/edit', component: GroupForm, meta: { new: false } },

  { name: 'alerters', path: '/alerters', component: Alerters },
  { name: 'alerters.new', path: '/alerters/new', component: AlerterForm, meta: { new: true } },
  { name: 'alerters.edit', path: '/alerters/:id/edit', component: AlerterForm, meta: { new: false } },

  { name: 'checks', path: '/checks', component: Checks },
  { name: 'check', path: '/check/:id', component: Check },
  { name: 'checks.new', path: '/checks/new', component: CheckForm, meta: { new: true } },
  { name: 'checks.edit', path: '/checks/:id/edit', component: CheckForm, meta: { new: false } },
];

export default new VueRouter({
  mode: 'history',
  routes
});
