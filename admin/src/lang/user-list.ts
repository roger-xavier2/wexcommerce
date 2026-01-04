import LocalizedStrings from 'localized-strings'

export const strings = new LocalizedStrings({
    fr: {
        EMPTY_LIST: "Pas d'uilisateurs",
        SUBSCRIBED_AT: 'Inscrit le',
        ORDERS: 'Commandes',
        DELETE_USER: "Êtes-vous sûr de vouloir supprimer cet utilisateur ?",
        USER_DELETED: 'Utilisateur supprimé.',
        DELETE_DISABLED_ADMIN: "Vous ne pouvez pas supprimer un administrateur."
    },
    en: {
        EMPTY_LIST: 'No users',
        SUBSCRIBED_AT: 'Subscribed at',
        ORDERS: 'Orders',
        DELETE_USER: 'Are you sure you want to delete this user?',
        USER_DELETED: 'User deleted.',
        DELETE_DISABLED_ADMIN: 'You cannot delete an admin user.'
    }
})
