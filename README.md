rhoconnect-rb
===

A ruby client library for the [Rhoconnect](http://rhomobile.com/products/rhosync) App Integration Server.

Using rhoconnect-rb, your application's model data will transparently synchronize with a mobile application built using the [Rhodes framework](http://rhomobile.com/products/rhodes), or any of the available [Rhoconnect clients](http://rhomobile.com/products/rhosync/).  This client includes built-in support for [ActiveRecord](http://ar.rubyonrails.org/) and [DataMapper](http://datamapper.org/) models.

## Getting started

Load the `rhoconnect-rb` library:

	require 'rhoconnect-rb'

Note, if you are using datamapper, install the `dm-serializer` library and require it in your application.  `rhoconnect-rb` depends on this utility to interact with Rhoconnect applications using JSON.
	
## Usage
Now include Rhoconnect::Resource in a model that you want to synchronize with your mobile application:

	class Product < ActiveRecord::Base
	  include Rhoconnect::Resource
	end
	
Or, if you are using DataMapper:

	class Product
	  include DataMapper::Resource
	  include Rhoconnect::Resource
	end
	
Next, your models will need to declare a partition key for `rhoconnect-rb`.  This partition key is used by `rhoconnect-rb` to uniquely identify the model dataset when it is stored in a Rhoconnect application.  It is typically an attribute on the model or related model.  `rhoconnect-rb` supports two types of partitions:

* :app - No unique key will be used, a shared dataset is used for all users.
* lambda { some lambda } - Execute a lambda which returns the unique key string.

For example, the `Product` model above might have a `belongs_to :user` relationship.  The partition identifying the username would be declared as:

	class Product < ActiveRecord::Base
	  include Rhoconnect::Resource
	  
	  belongs_to :user
	
	  partition lambda { self.user.username }
	end
	
For more information about Rhoconnect partitions, please refer to the [Rhoconnect docs](http://docs.rhomobile.com/rhosync/source-adapters#data-partitioning).

## Meta
Created and maintained by Vladimir Tarasov and Lars Burgess.

Released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).