# 
# redcloth_attributes.rb.rl
# 
# Copyright (C) 2009 Jason Garber
# 

%%{

  machine redcloth_attributes;
  include redcloth_common "redcloth_common.rb.rl";
  include redcloth_attributes "redcloth_attributes.rl";

}%%

module RedCloth
  module RedclothAttributes
    include BaseScanner

    def initialize
      %% write data nofinal;
      # % (gets syntax highlighting working again)
    end

    def redcloth_attribute_parser(machine, data)
      regs = {}

      %% write init;

      cs = machine

      %% write exec;

      return regs
    end

    def redcloth_attributes(str)
      cs = redcloth_attributes_en_inline
      return redcloth_attribute_parser(cs, str)
    end

    def redcloth_link_attributes(str)
      cs = redcloth_attributes_en_link_says;
      return redcloth_attribute_parser(cs, str)
    end
    
  end
end