# rails_lite

Note: Flash and Session hash keys must be strings.  
Note: Static files must go in a top level directory called "public/".  
Note: Snails standard is to both use and not use attr_readers as the mood and season dictates.  
Note: Have to add "self.finalize!" to models to create getters and setters.  

##Done  
Exception Handling  
Static Assets  
CSRF Protection    
Integrate Active Record Lite  

##Claimed  

##Todo  
Package as gem  
Make requires work properly across new file structure  
Make sure views and other file lookups work properly across new file structure  
make "snails new" work  
Allow users to add gems file  
Offer 3 environments: Dev, test, production  
Multiple gem files (one for user, one for snails)  

Middleware????  
Logging  
rake  

Fix ::finalize!, so we don't need it anymore  
make validations work  
has_many :through  
includes that does pre-fetching  
adds joins to active_record lite    
add all clauses to relations  
rake db:migrations  

multiple database support  

snails generate migration with DSL  

make a routes file  
rake routes  
add "patch" and "delete"  
Other helpers  
strong params  
URL helpers ex: "users_url"  

add "link_to" and "button_to"  
form helpers  
CSS  
SASS  
JavaScript?  
Helper methods    

404 Error catching and serving  

REFACTOR!!!  
Dealing with symbol/string conversion  
Rewrite App Academy code ex: DBConnection  
Plug and play functionality  

Testing  
Test Suite development  

Error Handling   
