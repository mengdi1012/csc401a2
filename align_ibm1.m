function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);
  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  eng = {};
  fre = {};
  DD = dir([mydir,filesep, '*', 'e']);
  count = 1;
  for iFile=1:length(DD)
    en_lines = textread([mydir,filesep,DD(iFile).name],'%s','delimiter','\n');
    fn_fr = regexprep(DD(iFile).name,'e$','f');
    fr_lines = textread([mydir,filesep,fn_fr],'%s','delimiter','\n');
    for iline=1:length(en_lines)
      eng{count} = strsplit(' ', preprocess(en_lines{iline}, 'e'));
      fre{count} = strsplit(' ', preprocess(fr_lines{iline}, 'f'));
      count = count + 1;
      if (count>numSentences)
        return;
      end
    end
  end
  % TODO: your code goes here.
end

function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
  AM = struct(); % AM.(english_word).(foreign_word)

  % TODO: your code goes here
  for isent=1:length(eng)
    for i=1:length(eng{isent})-1        %skip SENTSTART & SENTEND and add NULL
      if i==1
          eword = 'NULL';
      else
          eword = eng{isent}{i};
      end
      
      for j=2:length(fre{isent}) - 1    %skip SENTSTART & SENTEND
        fword = fre{isent}{j};
        if not (isfield(AM,eword) && isfield(AM.(eword),fword))
            AM.(eword).(fword) = 1;
        end       
      end
    end
  end
  e_words = fieldnames(AM);
  for i=1:length(e_words)
      eword = e_words{i};
      f_words = fieldnames(AM.(eword));
      count = length(f_words);
      for j=1:count
        AM.(eword).(f_words{j}) = 1/count;
      end
  end
  AM.SENTSTART.SENTSTART = 1;
  AM.SENTEND.SENTEND = 1;
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
% 
  tcount = struct();
  total = struct();
  for isent=1:length(eng)
    f_words = fre{isent};
    for i=2:length(f_words)-1           %skip SENTSTART & SENTEND and add NULL
      fword = f_words{i};
      denom_c = 0;
      e_words = eng{isent};
      for j=1:length(e_words)-1          %skip SENTSTART & SENTEND and add NULL
        if j==1
            eword = 'NULL';
        else  
            eword = e_words{j};
        end
        denom_c = denom_c + t.(eword).(fword);
      end
      for j=1:length(e_words)-1         %skip SENTSTART & SENTEND and add NULL
        if j==1
          eword = 'NULL';
        else
          eword = e_words{j};
        end
        x = t.(eword).(fword)/denom_c;
        if isfield(tcount,eword) && isfield(tcount.(eword),fword)
          tcount.(eword).(fword) = tcount.(eword).(fword) + x;
        else
           tcount.(eword).(fword) = x;
        end
        if isfield(total,eword)
          total.(eword) = total.(eword) + x;
        else
          total.(eword) = x;
        end
      end
    end
  end
  
  e_words = fieldnames(total);
  for i=1:length(e_words)     
    eword = e_words{i};
    f_words = fieldnames(tcount.(eword));
    for k=1:length(f_words)        
      fword =f_words{k};
      t.(eword).(fword) = tcount.(eword).(fword) / total.(eword);
    end
  end
  % TODO: your code goes here
end


