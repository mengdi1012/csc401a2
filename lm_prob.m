function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    if (nargin<5)
       vocabSize = length(fieldnames(LM.uni));
    end
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  % TODO: the student implements the following
  p = 1;
  for w=2:length(words)
    w1 = words{w-1};
    w2 = words{w};
    total = vocabSize * delta;
    count = delta;
    if isfield(LM.uni, w1)
      total = total + LM.uni.(w1);
    end
    if isfield(LM.bi,w1) && isfield(LM.bi.(w1), w2)
      count = count + LM.bi.(w1).(w2);
    end
    % return -inf if count is 0
    if count == 0 || total==0
      return
    end
    p = p * (count/total);
  end
  logProb = log2(p);
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return