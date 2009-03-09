/*
 * redcloth_scan.rb.rl
 *
 * Copyright (C) 2009 Jason Garber
 */


%%{

  machine redcloth_scan;
  include redcloth_common "redcloth_common.rb.rl";

  action extend { extend = regs["type"] }

  include redcloth_scan "redcloth_scan.rl";

}%%

  %% write data nofinal;

/* %% (gets syntax highlighting working again) */

module RedCloth
  class TextileDoc < String
    attr_accessor :p, :pe, :eof, :refs, :orig_data, :nest, :html,
      :table, :block, :reg, :regs, :list_layout, :list_index, :list_continue,
      :listm, :refs_found
    
    def to(formatter)
      self.delete!("\r")
      working_copy = self.clone
      working_copy.extend(formatter)

      if (working_copy.lite_mode
        return redcloth_inline2(working_copy, self, {});
      else
        return redcloth_transform2(working_copy, self);
      }
    end
    
    class ParseError < Exception; end
    
    def redcloth_transform(data, refs)
      orig_data = data.dup
      nest = 0
      html = ""
      table = ""
      block = ""
      CLEAR_REGS()


      list_layout = nil
      list_index = [];
      list_continue = 0;
      SET_PLAIN_BLOCK("p")
      extend = nil
      listm = []
      refs_found = {}

      %% write init;

      %% write exec;

      if (block.length > 0)
      {
        ADD_BLOCK()
      }

      if ( refs.nil? && !refs_found.empty? ) {
        return redcloth_transform(orig_data, refs_found);
      } else {
        self.after_transform(html)
        return html
      }
    end
    
    def redcloth_transform2(str)
      before_transform(str)
      return redcloth_transform(str, nil);
    }
    
    def html_esc(str, level=nil)
      return "" if str.nil? || str.empty?

      str.gsub!('&') { amp({}) }
      str.gsub!('>') { gt({}) }
      str.gsub!('<') { lt({}) }
      if level != :html_escape_preformatted
        str.gsub!("\n") { br({}) }
        str.gsub!('"') { quot({}) }
        str.gsub!("'") { level == :html_escape_attributes ? apos({}) : squot({}) }
      end
      return str;
    end
    
    def latex_esc(str)
      return "" if str.nil? || str.empty?
      
      str.gsub!('{') { entity({:text => "#123"}) }
      str.gsub!('}') { entity({:text => "#125"}) }
      str.gsub!('\\') { entity({:text => "#92"}) }
      str.gsub!('#') { entity({:text => "#35"}) }
      str.gsub!('$') { entity({:text => "#36"}) }
      str.gsub!('%') { entity({:text => "#37"}) }
      str.gsub!('&') { entity({:text => "amp"}) }
      str.gsub!('_') { entity({:text => "#95"}) }
      str.gsub!('^') { entity({:text => "circ"}) }
      str.gsub!('~') { entity({:text => "tilde"}) }
      str.gsub!('<') { entity({:text => "lt"}) }
      str.gsub!('>') { entity({:text => "gt"}) }
      str.gsub!('\n') { entity({:text => "#10"}) }
      
      return str
    end
    
    
    def STR_NEW(p,n) 
#FIXME      rb_enc_str_new((p),(n),rb_utf8_encoding())
    end

    # parser macros
    def CLEAR_REGS()
      @regs = {}
    end
    def RESET_REG()
      @reg = nil
    end
    def CAT(h)
      h << data[ts, te-ts]
    end
    def CLEAR(h)
      h = ""
    end
    def RSTRIP_BANG(h)
      h.rstrip!
    end
    def SET_PLAIN_BLOCK(t) 
      @plain_block = t
    end
    def RESET_TYPE(t)
      @regs[:type] = plain_block
    end
    def INLINE(h, t)
      h << self.call(t, regs)
    end
    def DONE(h)
      html << h
      CLEAR(h)
      CLEAR_REGS()
    end
    def PASS(h, a, t)
      h << red_pass(regs, a.to_sym, t, refs))
    end
    def PARSE_ATTR(a)
      red_parse_attr(regs, a)
    end
    def PARSE_LINK_ATTR(a)
      red_parse_link_attr(regs, a)
    end
    def PARSE_IMAGE_ATTR(a)
      red_parse_image_attr(regs, a)
    end
    def PASS_CODE(h, a, t, o)
      h << red_pass_code(@regs, a, t))
    def ADD_BLOCK()
      @html << red_block(@regs, @block, @refs)
      @extend = nil
      CLEAR(block)
      CLEAR_REGS()
    end
    def ADD_EXTENDED_BLOCK()
      @html << red_block(@regs, @block, @refs))
      CLEAR(@block)
    end
    def END_EXTENDED()
      @extend = nil
      CLEAR_REGS()
    end
    def IS_NOT_EXTENDED()
      @extend.nil?
    end
    def ADD_BLOCKCODE()
      @html << red_blockcode(@regs, @block)
      CLEAR(@block)
      CLEAR_REGS()
    end
    def ADD_EXTENDED_BLOCKCODE()
      @html << red_blockcode(@regs, @block)
      CLEAR(block)
    end
    def ASET(t, v)
      @regs[t] = v
    end
    def AINC(t)
      red_inc(@regs, t)
    end
    def SET_ATTRIBUTES()
      SET_ATTRIBUTE("class_buf", "class")
      SET_ATTRIBUTE("id_buf", "id")
      SET_ATTRIBUTE("lang_buf", "lang")
      SET_ATTRIBUTE("style_buf", "style")
    end
    def SET_ATTRIBUTE(b, a)
      @regs[a] = @regs[b] unless @regs[b].nil?
    end
    def TRANSFORM(t)
      if (p > reg && reg >= ts)
        str = redcloth_transform(reg, p, refs)
        regs[t] = str
        # /*printf("TRANSFORM(" T ") '%s' (p:'%s' reg:'%s')\n", RSTRING_PTR(str), p, reg);*/  \
      else
        regs[t] = nil
      end
    end
    def STORE(t)
      if (p > reg && reg >= ts)
        str = data[reg, p-reg]
        regs[t] = str
        # /*printf("STORE(" T ") '%s' (p:'%s' reg:'%s')\n", RSTRING_PTR(str), p, reg);*/  \
      else
        regs[t] = nil
      end
    end
    def STORE_B(t)
      if (p > bck && bck >= ts)
        str = data[bck, p-bck)]
        regs[t] = str
        # /*printf("STORE_B(" T ") '%s' (p:'%s' reg:'%s')\n", RSTRING_PTR(str), p, reg);*/  \
      else
        regs[t] = nil
      end
    end
    def STORE_URL(t)
      if (p > reg && reg >= ts)
        punct = true
        while (p > reg && punct)
          case data[p - 1, 1]
            when ')'
              temp_p = p - 1
              level = -1
              while (temp_p > reg)
                case data[temp_p - 1, 1]
                  when '('; level += 1
                  when ')'; level -= 1
                end
                temp_p -= 1
              end
              if (level == 0) 
                punct = 0
              else
                p -= 1
              end
            when '!', '"', '#', '$', '%', ']', '[', '&', '\'',
              '*', '+', ',', '-', '.', '(', ':', ';', '=', 
              '?', '@', '\\', '^', '_', '`', '|', '~'
                p -= 1
            else
              punct = 0
            end
          end
        end
        te = p
      end
      STORE(t)
      if ( !refs.nil? && refs.has_key?(regs[t]) )
        regs[t] = refs[regs[t]]
      end
    end
    def STORE_LINK_ALIAS()
      refs_found[regs[:text]] = regs[:href]
    end
    def CLEAR_LIST()
      list_layout = []
    end
    #define LIST_ITEM() \
        int aint = 0; \
        VALUE aval = rb_ary_entry(list_index, nest-1); \
        if (aval != Qnil) aint = NUM2INT(aval); \
        if (strcmp(list_type, "ol") == 0) \
        { \
          rb_ary_store(list_index, nest-1, INT2NUM(aint + 1)); \
        } \
        if (nest > RARRAY_LEN(list_layout)) \
        { \
          sprintf(listm, "%s_open", list_type); \
          if (list_continue == 1) \
          { \
            list_continue = 0; \
            rb_hash_aset(regs, ID2SYM(rb_intern("start")), rb_ary_entry(list_index, nest-1)); \
          } \
          else \
          { \
            VALUE start = rb_hash_aref(regs, ID2SYM(rb_intern("start"))); \
            if (NIL_P(start) ) \
            { \
              rb_ary_store(list_index, nest-1, INT2NUM(1)); \
            } \
            else \
            { \
              VALUE start_num = rb_funcall(start,rb_intern("to_i"),0); \
              rb_ary_store(list_index, nest-1, start_num); \
            } \
          } \
          rb_hash_aset(regs, ID2SYM(rb_intern("nest")), INT2NUM(nest)); \
          rb_str_append(html, rb_funcall(self, rb_intern(listm), 1, regs)); \
          rb_ary_store(list_layout, nest-1, STR_NEW2(list_type)); \
          CLEAR_REGS(); \
          ASET("first", "true"); \
        } \
        LIST_CLOSE(); \
        rb_hash_aset(regs, ID2SYM(rb_intern("nest")), INT2NUM(RARRAY_LEN(list_layout))); \
        ASET("type", "li_open")
    #define LIST_CLOSE() \
        while (nest < RARRAY_LEN(list_layout)) \
        { \
          rb_hash_aset(regs, ID2SYM(rb_intern("nest")), INT2NUM(RARRAY_LEN(list_layout))); \
          VALUE end_list = rb_ary_pop(list_layout); \
          if (!NIL_P(end_list)) \
          { \
            StringValue(end_list); \
            sprintf(listm, "%s_close", RSTRING_PTR(end_list)); \
            rb_str_append(html, rb_funcall(self, rb_intern(listm), 1, regs)); \
          } \
        }

    #endif
    
    
  end
end