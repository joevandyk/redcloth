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

    def write_attributes_machine
      %%{
        # All other variables become local, letting Ruby garbage collect them. This
        # prevents us from having to manually reset them.

        variable data  @data;
        variable p     @p;
        variable pe    @pe;
        variable cs    @cs;
        variable ts    @ts;
        variable te    @te;

        write data nofinal;
      }%%
    end

    def redcloth_attribute_parser(machine, data)
      %% write init; #%
      
      @data = data
      @regs = {}
      @p = 0
      @pe = @data.length

      cs = machine

      %% write exec; #%

      return @regs
    end

    def redcloth_attributes(str)
      write_attributes_machine
      self.cs = self.redcloth_attributes_en_inline
      return redcloth_attribute_parser(cs, str)
    end

    def redcloth_link_attributes(str)
      write_attributes_machine
      self.cs = self.redcloth_attributes_en_link_says;
      return redcloth_attribute_parser(cs, str)
    end
    
  end
end