rhosync-rb
===

A ruby client library for the [RhoSync](http://rhomobile.com/products/rhosync) App Integration Server.  

Using rhosync-rb, your application's model data will transparently synchronize with a mobile application built using the [Rhodes framework](http://rhomobile.com/products/rhodes), or any of the available [RhoSync clients](http://rhomobile.com/products/rhosync/).  This client includes built-in support for [ActiveRecord](http://ar.rubyonrails.org/) and [DataMapper](http://datamapper.org/) models. 

## Getting started

Load the `rhosync-rb` library:

	require 'rhosync-rb'

Note, if you are using datamapper, install the `dm-serializer` library and require it in your application.  `rhosync-rb` depends on this utility to interact with RhoSync applications using JSON.
	
## Usage
Now include Rhosync::Resource in a model that you want to synchronize with your mobile application:

	class User < ActiveRecord::Base
	  include Rhosync::Resource
	end
	
Or, if you are using DataMapper:

	class User
	  include DataMapper::Resource
	  include Rhosync::Resource
	end
	
Next, your models will need to declare a partition key for `rhosync-rb`.  This partition key is used by `rhosync-rb` to uniquely identify the model dataset when it is stored in a RhoSync application.  It is typically an attribute on the model or related model.  `rhosync-rb` supports three types of partitions: 

* :app - no unique key will be used, a single dataset is used for all users
* { some lambda } - execute a block which returns the key string

For example, the `User` model above might have a 'username' attribute.  The partition would be declared as:

	class User < ActiveRecord::Base
	  include Rhosync::Resource
	
	  partition { self.username }
	end

## Meta
Created and maintained by Vladimir Tarasov and Lars Burgess.

Released under the [MIT License](http://www.opensource.org/licenses/mit-license.php)