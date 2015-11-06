# Component routes
get '/images/{{ height }}/{{ width }}/{{ crop }}/{{ *image_url }}', component: 's3_image_resizer', controller: 'resizer', action: 'index'
