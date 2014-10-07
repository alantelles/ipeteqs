#coding:utf-8
@pub_vars=[]
class Object
  def imprima(args='')
    "print #{exp_converter(args)}; "
  end
  def imprimaln(args='')
    code="print #{exp_converter(args)}; "
    puts exp_converter(args)
    code<<"puts; "
    code
  end
  def leia args #neessita ajeitar
    code=""
    ar_args=args.split(",")
    ar_args.each do |arg|
      code<<arg+"=gets.chomp; "
      code<<"if #{arg}.to_i.to_s == #{arg}; "
      code<<"  #{arg}=#{arg}.to_i; "
      code<< "end; "
    end
    code
  end
  #atribui recebe command+args
  def atribui(args)
    pos=args=~/\<-/
    if pos==nil
      #é chamada de função
      args
    else
      equal="="
      args+"; "
      vari=args[0..pos-1]
      vari.rstrip!
      vari.lstrip!
      valor=args[pos+2..args.length-1]
      valor.lstrip!
      valor.rstrip!
      if valor=='VERDADEIRO'
        valor='true'
      elsif valor=='FALSO'
        valor='false'
      end
      if @in_function && vari=='resultado'
        vari=''
        equal=''
      end
      if !@in_function
        @pub_vars<<vari
        valor="Variavel.new(#{valor})"
      end
      vari+equal+valor+"; "
    end
  end
  def se(cond)
    cond.rstrip!
    cond=cond[0..-6]#retira entao
    cond.rstrip!
    cond.lstrip!
    "if "+cond+"; "
  end
  #args pode ter um senao
  def senao(args='')
    if args[0..1]=="se"
      cond=cond[0..2]#retira se
      cond.lstrip!
      senao_se=se cond
      "els"+senao_se+"; "
    else
      "else; "
    end
  end
  def enquanto(cond)
    cond.rstrip!
    cond=cond[0..-5]#retira faca
    cond.rstrip!
    "while "+cond+"; "
  end
  def para(args)
    args=args[0..-4]
    args.rstrip!
    pos=args=~/<-/
    vari=args[0..pos-1]
    args=args[pos+2..args.length]
    pos=args=~/até/
    start=args[0..pos-2]
    start.rstrip!
    stop=args[pos+4..args.length-2]
    stop.rstrip!
    "ptq_para "+start+","+stop+" do |"+vari+"|;  "
  end
  def ptq_para(start,stop)
    if start<=stop
      (start..stop).each do |code|
        yield code
      end
    else
      (stop..start).reverse_each do |code|
        yield code
      end
    end
  end
  def funcao(args)
    par=args=~/\(/
    name_func=args[0..par-1]
    name_func.rstrip!
    arg_list=args[par..args.length-1]
    arg_list.lstrip!
    arg_list.rstrip!
    @in_function=true
    "def "+name_func+arg_list+"; "
  end
  def fim
    puts 'vim ca'
    if @in_function
      @in_function=false
    end
  end
  def is_num? arg
    is_float=arg == arg.to_f.to_s
    is_fixnum=arg == arg.to_i.to_s
    is_float || is_fixnum
  end
  def exp_converter(arg)
    sig=["+","-","*","/"," mod ",")",","]
    conc=""
    final=""
    arg.each_char do |c|
      oper=sig.include? c
      if oper
        if !is_num?(conc) && conc!=""
          if conc[0]!="'" && conc[conc.length-1]!="'"
            conc<<".valor"
          end
        end
        conc<<c
        final<<conc
        conc="";
      else
        conc<<c
      end
    end
    if !is_num?(conc) && conc!=""
      if conc[0]!="'" && conc[conc.length-1]!="'"
        conc<<".valor"
      end
    end
    final<<conc
    final
  end
  def analyze(line)
    line.rstrip!
    line.lstrip!
    space=line=~/ /
    attr=line=~/<-/
    reserved_words=['senão','fim','início','função']
    if (((attr.to_i < space.to_i && space.to_i != 0) && attr != nil ) || space == nil) && (!reserved_words.include?(line))
      atribui line
    elsif line=='senão'
      senao
    elsif line=='fim'
      "end; "
    else
      command=line[0..space]
      command.lstrip!
      command.rstrip!
      args=line[space..line.length-1]
      args.lstrip!
      case command
      when "imprima"
        imprima args
      when "imprimaln"
        imprimaln args
      when "leia"
        leia args
      when "para"
        para args
      when "se"
        se args
      when "enquanto"
        enquanto args
      when "função"
        funcao args
      when "procedimento"
        procedimento args
      when "fim"
        fim
      when "próximo"
        "end; "
      when "início"
        "#inicio; "
      end
    end
  end
  def execute (code)
    ruby_code=""
    code.lines do |line|
      ruby_code<<analyze(line)
      puts @in_function.to_s
    end
    puts 'Código Ruby'
    puts '======================='
    ar_ruby_code=ruby_code.split("; ")
    ar_ruby_code.each do |ruby_line|
      puts ruby_line+" -- "+@in_function.to_s
    end
    puts '======================='
    puts 'Código Peteqs'
    puts '======================='
    eval(ruby_code)
  end
end
class Variavel
  attr_accessor :valor
  def initialize(arg)
    self.valor=arg
  end
end
@in_function=false
str="função teste()
início
x<-3
fim"
execute str
