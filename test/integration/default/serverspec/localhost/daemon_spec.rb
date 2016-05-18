require 'spec_helper'

describe service('oozie') do  
  it { should be_enabled   }
  it { should be_running   }
end 

