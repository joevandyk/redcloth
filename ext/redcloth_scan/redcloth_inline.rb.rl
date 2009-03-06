/*
 * redcloth_inline.rb.rl
 *
 * Copyright (C) 2009 Jason Garber
 */

%%{

  machine redcloth_inline;
  include redcloth_common "redcloth_common.rb.rl";
  include redcloth_inline "redcloth_inline.rl";

}%%

%% write data nofinal;

def red_pass(regs, ref, meth, refs)
  txt = regs[ref]
  if (!txt.nil?) regs[ref] = redcloth_inline2(self, txt, refs)
  return self.call(meth, regs)
}

def red_parse_attr(regs, ref)
  txt = regs[ref]
  new_regs = redcloth_attributes(self, txt)
  return regs.update(new_regs)
end

def red_parse_link_attr(regs, ref)
  txt = regs[ref]
  new_regs = red_parse_title(redcloth_link_attributes(self, txt), ref)
  
  return regs.update(new_regs)
end

def red_parse_image_attr(regs, ref)
  return red_parse_title(regs, ref);
end

def red_parse_title(regs, ref)
  # Store title/alt
  name = regs[ref]
  if ( !name.nil? ) {
    s = name.to_s
    p = s.length
    if (s[p - 1,1] == ')')
      level = -1
      p -= 1
      while (p > 0 && level < 0) do
        case(s[p - 1, 1]) {
          when '('; ++level
          when ')'; --level
        }
        p -= 1
      }
      title = s[p + 1, s.length - 1])
      p -= 1 if (p > 0 && s[p - 1, 1] == ' ')
      if (p != 0)
        regs[ref] = s[0, p]
        regs[:title] = title
      end
    end
  end
  return regs;
end

def red_pass_code(regs, ref, meth)
  txt = regs[ref]
  if (!txt.nil?)
    txt2 = ""
    rb_str_cat_escaped_for_preformatted(txt2, text)
    regs[ref] = txt2
  }
  return self.call(meth, regs)
end

def red_block(regs, block, refs)
  sym_text = :text
  btype = regs[:type]
  block = block.strip
  if (!block.nil? && !btype.nil?)
    method = btype.intern
    if (method == :notextile)
      regs[sym_text] = block
    else
      regs[sym_text] = redcloth_inline2(block, refs))
    end
    if (self.formatter_methods.includes? method)
      block = self.call(method, regs)
    else
      fallback = regs[:fallback]
      if (!fallback.nil?) {
        fallback << regs[sym_text]
        CLEAR_REGS()
        regs[sym_text] = fallback
      }
      block = self.p(regs);
    }
  }
  return block
end

def red_blockcode(regs, block)
  btype = regs[:type]
  if (block.length > 0)
    regs[:text] = block
    block = self.call(btype, regs)
  end
  return block
end

def red_inc(regs, ref)
  aint = 0
  aval = regs[ref]
  aint = aval.to_i if (!aval.nil?)
  regs[ref] = aint + 1
end

def redcloth_inline(data, refs)
  orig_data = data;
  block = ""
  regs = nil
  
  %% write init;

  %% write exec;

  return block
end

# Append characters to a string, escaping (&, <, >, ", ') using the formatter's escape method.
# @param str ruby string
# @param ts  start of character buffer to append
# @param te  end of character buffer
#
def rb_str_cat_escaped(self, str, ts, te)
  source_str = STR_NEW(ts, te-ts);
  escaped_str = self.escape(source_str)
  str << escaped_str
end

def rb_str_cat_escaped_for_preformatted(str, ts, te)
  source_str = STR_NEW(ts, te-ts);
  escaped_str = self.escape_pre(source_str)
  str << escaped_str
end

def redcloth_inline2(str, refs)
  return redcloth_inline(str, refs);
end
