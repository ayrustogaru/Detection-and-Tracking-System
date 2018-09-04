function [X,ndx,dbg] = natsort(X,xpr,varargin)
%% Input Wrangling %%
%
assert(iscell(X),'First input <X> must be a cell array.')
tmp = cellfun('isclass',X,'char') & cellfun('size',X,1)<2 & cellfun('ndims',X)<3;
assert(all(tmp(:)),'First input <X> must be a cell array of char row vectors (1xN char).')
%
% Regular expression:
if nargin<2 || isnumeric(xpr)&&isempty(xpr)
	xpr = '\d+';
else
	assert(ischar(xpr)&&isrow(xpr),'Second input <xpr> must be a regular expression (char row vector).')
end
%
% Optional arguments:
tmp = cellfun('isclass',varargin,'char') & 1==cellfun('size',varargin,1) & 2==cellfun('ndims',varargin);
assert(all(tmp(:)),'All optional arguments must be char row vectors (1xN char).')
% Character case matching:
ChrM = strcmpi(varargin,'matchcase');
ChrX = strcmpi(varargin,'ignorecase')|ChrM;
% Sort direction:
DrnD = strcmpi(varargin,'descend');
DrnX = strcmpi(varargin,'ascend')|DrnD;
% Relative sort-order of numbers compared to characters:
RsoB = strcmpi(varargin,'beforechar');
RsoA = strcmpi(varargin,'afterchar');
RsoX = strcmpi(varargin,'asdigit')|RsoB|RsoA;
% SSCANF conversion format:
FmtX = ~(ChrX|DrnX|RsoX);
%
if nnz(FmtX)>1
	tmp = sprintf(', ''%s''',varargin{FmtX});
	error('Overspecified optional arguments:%s.',tmp(2:end))
end
if nnz(DrnX)>1
	tmp = sprintf(', ''%s''',varargin{DrnX});
	error('Sort direction is overspecified:%s.',tmp(2:end))
end
if nnz(RsoX)>1
	tmp = sprintf(', ''%s''',varargin{RsoX});
	error('Relative sort-order is overspecified:%s.',tmp(2:end))
end
%
%% Split Strings %%
%
% Split strings into number and remaining substrings:
[MtS,MtE,MtC,SpC] = regexpi(X(:),xpr,'start','end','match','split',varargin{ChrX});
%
% Determine lengths:
MtcD = cellfun(@minus,MtE,MtS,'UniformOutput',false);
LenZ = cellfun('length',X(:))-cellfun(@sum,MtcD);
LenY = max(LenZ);
LenX = numel(MtC);
%
dbg = cell(LenX,LenY);
NuI = false(LenX,LenY);
ChI = false(LenX,LenY);
ChA = char(double(ChI));
%
ndx = 1:LenX;
for k = ndx(LenZ>0)
	% Determine indices of numbers and characters:
	ChI(k,1:LenZ(k)) = true;
	if ~isempty(MtS{k})
		tmp = MtE{k} - cumsum(MtcD{k});
		dbg(k,tmp) = MtC{k};
		NuI(k,tmp) = true;
		ChI(k,tmp) = false;
	end
	% Transfer characters into char array:
	if any(ChI(k,:))
		tmp = SpC{k};
		ChA(k,ChI(k,:)) = [tmp{:}];
	end
end
%
%% Convert Number Substrings %%
%
if nnz(FmtX) % One format specifier
	fmt = varargin{FmtX};
	err = ['The supplied format results in an empty output from sscanf: ''',fmt,''''];
	pct = '(?<!%)(%%)*%'; % match an odd number of % characters.
	[T,S] = regexp(fmt,[pct,'(\d*)([bdiuoxfeg]|l[diuox])'],'tokens','split');
	assert(isscalar(T),'Unsupported optional argument: ''%s''',fmt)
	assert(isempty(T{1}{2}),'Format specifier cannot include field-width: ''%s''',fmt)
	switch T{1}{3}(1)
		case 'b' % binary
			fmt = regexprep(fmt,[pct,'(\*?)b'],'$1%$2[01]');
			val = dbg(NuI);
			if numel(S{1})<2 || ~strcmpi('0B',S{1}(end-1:end))
				% Remove '0B' if not specified in the format string:
				val = regexprep(val,'(0B)?([01]+)','$2','ignorecase');
			end
			val = cellfun(@(s)sscanf(s,fmt),val, 'UniformOutput',false);
			assert(~any(cellfun('isempty',val)),err)
			NuA(NuI) = cellfun(@(s)sum(pow2(s-'0',numel(s)-1:-1:0)),val);
		case 'l' % 64-bit
			NuA(NuI) = cellfun(@(s)sscanf(s,fmt),dbg(NuI)); %slow!
		otherwise % double
			NuA(NuI) = sscanf(sprintf('%s\v',dbg{NuI}),[fmt,'\v']); % fast!
	end
else % No format specifier -> double
	NuA(NuI) = sscanf(sprintf('%s\v',dbg{NuI}),'%f\v');
end
% Note: NuA's class is determined by SSCANF or the custom binary parser.
NuA(~NuI) = 0;
NuA = reshape(NuA,LenX,LenY);
%
%% Debugging Array %%
%
if nargout>2
	dbg(:) = {''};
	for k = reshape(find(NuI),1,[])
		dbg{k} = NuA(k);
	end
	for k = reshape(find(ChI),1,[])
		dbg{k} = ChA(k);
	end
end
%
%% Sort Columns %%
%
if ~any(ChrM) % ignorecase
	ChA = upper(ChA);
end
%
ide = ndx.';
% From the last column to the first...
for n = LenY:-1:1
	% ...sort the characters and number values:
	[C,idc] = sort(ChA(ndx,n),1,varargin{DrnX});
	[~,idn] = sort(NuA(ndx,n),1,varargin{DrnX});
	% ...keep only relevant indices:
	jdc = ChI(ndx(idc),n); % character
	jdn = NuI(ndx(idn),n); % number
	jde = ~ChI(ndx,n)&~NuI(ndx,n); % empty
	% ...define the sort-order of numbers and characters:
	jdo = any(RsoA)|(~any(RsoB)&C<'0');
	% ...then combine these indices in the requested direction:
	if any(DrnD) % descending
		idx = [idc(jdc&~jdo);idn(jdn);idc(jdc&jdo);ide(jde)];
	else % ascending
		idx = [ide(jde);idc(jdc&jdo);idn(jdn);idc(jdc&~jdo)];
	end
	ndx = ndx(idx);
end
%
ndx  = reshape(ndx,size(X));
X = X(ndx);
%
end