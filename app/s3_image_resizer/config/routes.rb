# Component routes
get '/images/{{ height }}/{{ width }}/{{ crop }}/{{ *image_url }}', component: 'image_resizer', controller: 'resizer', action: 'index'
