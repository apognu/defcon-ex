import 'bootstrap';
import 'lodash';
import '../css/app.scss';

import Vue from 'vue';
import router from './router';
import VueTippy, { TippyComponent } from 'vue-tippy';
import App from '@/components/App';

Vue.config.productionTip = false;
Vue.use(VueTippy);

Vue.component('tippy', TippyComponent);

new Vue({
  el: '#app',
  router,
  components: { App }
});
