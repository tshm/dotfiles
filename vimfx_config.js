/* global vimfx Components */
const {classes: Cc, interfaces: Ci, utils: Cu} = Components
const {Preferences} = Cu.import('resource://gre/modules/Preferences.jsm', {})
console.log(Cc, Ci)
console.log(Preferences)

vimfx.addKeyOverrides(
  [ location => location.hostname === 'getpocket.com',
    ['j', 'k', 'a', 'o', 'r', 's', 'o', 'n', '?']
  ]
)

vimfx.addKeyOverrides(
  [ location => location.hostname === 'mail.google.com',
    ['j', 'k', 'a', 'o', 'I', 'e', 'g', 'x', 'p', 'n', '?']
  ]
)
