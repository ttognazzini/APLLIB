import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import SignOnView from '@/views/SignOnView.vue'
import HomeView from '@/views/HomeView.vue'
import PlaceholderView from '@/views/PlaceholderView.vue'
import SegmentsView from '@/views/SegmentsView.vue'
import DictionariesView from '@/views/DictionariesView.vue'
import DictionaryDetailView from '@/views/DictionaryDetailView.vue'

/** Content for the ⓘ info modal a page can offer from the standard header. */
export interface PageHelp {
  title: string
  paragraphs: string[]
}

declare module 'vue-router' {
  interface RouteMeta {
    /** Route is reachable without signing on */
    public?: boolean
    /** Page title shown in the standard header (RULES.md U2) */
    title?: string
    /** Optional explainer shown via the header's ⓘ icon (RULES.md U2) */
    help?: PageHelp
  }
}

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/signon', name: 'signon', component: SignOnView, meta: { public: true } },
    { path: '/', name: 'home', component: HomeView, meta: { title: 'Home' } },
    {
      path: '/segments',
      name: 'segments',
      component: SegmentsView,
      meta: {
        title: 'Segments',
        help: {
          title: 'What are segments?',
          paragraphs: [
            'A segment is a short code — 1 to 3 letters or numbers — that stands for a word or phrase. For example: itm = Item, nbr = Number, cpn = Component.',
            'Field (column) names are built by combining segments, so every developer naming a field for the same concept arrives at the same name. An item number field is always itmNbr; a component item field is always cpnItm.',
            'The dictionary system uses the segments to automatically generate the SQL column name from the field name: itmNbr becomes the column item_number. The system supports both the native IBM i field/file names and the modern SQL table/column naming conventions.',
            'A field named this way is defined once in a dictionary together with its attributes, such as type and size. Every file that includes the field pulls the same attributes from the dictionary, so item_number is identical in every table that uses it.',
            'Some segments stand for more than one word or phrase — for example CNF = Conflict/Config and COL = Column/Collection. The "Conflicts exist" flag marks these segments so you know the code has multiple meanings.',
          ],
        },
      },
    },
    {
      path: '/dictionaries',
      name: 'dictionaries',
      component: DictionariesView,
      meta: {
        title: 'Dictionaries',
        help: {
          title: 'What are dictionaries?',
          paragraphs: [
            'A dictionary is a central catalog of field definitions. A field is defined once — its name, SQL name, type, length, and display text — and every file that includes the field pulls the same definition, so a column like item_number is identical in every table that uses it.',
            'Multiple dictionaries can be configured (for example APLDCT for the development tools, ERPDCT for new ERP tables, MRPDCT for MRPS38S files). Each dictionary carries its own list of fields.',
            'Every field references a field type (CHAR, DECIMAL, VARCHAR, …). The type carries rules — whether a length is allowed or required, whether decimal positions are allowed, maximums — that are enforced when a field is defined.',
            'A field can be marked as enumerated: its list of allowed values is defined here, each with the stored value and the description shown on screens and in lists.',
          ],
        },
      },
    },
    {
      path: '/dictionaries/:name',
      name: 'dictionary-detail',
      component: DictionaryDetailView,
      meta: { title: 'Dictionary Fields' },
    },
    { path: '/files', name: 'files', component: PlaceholderView, meta: { title: 'Files' } },
  ],
})

// Everything except routes marked public requires a signed-on user.
router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.public !== true && !auth.signedOn) {
    return { name: 'signon', query: { redirect: to.fullPath } }
  }
  if (to.name === 'signon' && auth.signedOn) {
    return { name: 'home' }
  }
})

export default router
