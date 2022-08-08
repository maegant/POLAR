function obj = vectorizeFeedback(obj)
% Description: construct vectorized feedback indices and labels

%% Preference Feedback:
if ~isempty(obj.pref_data)
    % get vector of all preferred vs non preferred action indices
    preferred_first = obj.pref_labels == 1;
    obj.pref_pos_ind = [obj.pref_data(preferred_first,1);...
        obj.pref_data(~preferred_first,2)];
    obj.pref_neg_ind = [obj.pref_data(preferred_first,2);...
        obj.pref_data(~preferred_first,1)];
    
    % get unique feedback indices
    [obj.pref_pos_unique_inds,~,~] = unique(obj.pref_pos_ind);
    [obj.pref_neg_unique_inds,~,~] = unique(obj.pref_neg_ind);
    
    % get positions of repeating data to be added together
    obj.pref_pos_repeating_inds = obj.pref_pos_ind == obj.pref_pos_unique_inds';
    obj.pref_neg_repeating_inds = obj.pref_neg_ind == obj.pref_neg_unique_inds';
    
    % convert [x,y] subscripts to linear indices for vectorization
    sz = size(obj.prior_cov_inv);
    pospos = sub2ind(sz,obj.pref_pos_ind,obj.pref_pos_ind);
    negneg = sub2ind(sz,obj.pref_neg_ind,obj.pref_neg_ind);
    posneg = sub2ind(sz,obj.pref_pos_ind,obj.pref_neg_ind);
    negpos = sub2ind(sz,obj.pref_neg_ind,obj.pref_pos_ind);
    
    % get repeated indices
    [obj.pref_pospos_unique_inds,~,~] = unique(pospos);
    [obj.pref_negneg_unique_inds,~,~] = unique(negneg);
    [obj.pref_posneg_unique_inds,~,~] = unique(posneg);
    [obj.pref_negpos_unique_inds,~,~] = unique(negpos);
    obj.pref_pospos_repeating_inds = pospos == obj.pref_pospos_unique_inds';
    obj.pref_negneg_repeating_inds = negneg == obj.pref_negneg_unique_inds';
    obj.pref_posneg_repeating_inds = posneg == obj.pref_posneg_unique_inds';
    obj.pref_negpos_repeating_inds = negpos == obj.pref_negpos_unique_inds';
end
%% Coactive Feedback:
if ~isempty(obj.coac_data)
% get vector of all preferred vs non preferred action indices
preferred_first = obj.coac_labels == 1;
obj.coac_pos_ind = [obj.coac_data(preferred_first,1);...
    obj.coac_data(~preferred_first,2)];
obj.coac_neg_ind = [obj.coac_data(preferred_first,2);...
    obj.coac_data(~preferred_first,1)];

% get unique feedback indices
[obj.coac_pos_unique_inds,~,~] = unique(obj.coac_pos_ind);
[obj.coac_neg_unique_inds,~,~] = unique(obj.coac_neg_ind);

% get positions of repeating data to be added together
obj.coac_pos_repeating_inds = obj.coac_pos_ind == obj.coac_pos_unique_inds';
obj.coac_neg_repeating_inds = obj.coac_neg_ind == obj.coac_neg_unique_inds';

% convert [x,y] subscripts to linear indices for vectorization
sz = size(obj.prior_cov_inv);
pospos = sub2ind(sz,obj.coac_pos_ind,obj.coac_pos_ind);
negneg = sub2ind(sz,obj.coac_neg_ind,obj.coac_neg_ind);
posneg = sub2ind(sz,obj.coac_pos_ind,obj.coac_neg_ind);
negpos = sub2ind(sz,obj.coac_neg_ind,obj.coac_pos_ind);

% get repeated indices
[obj.coac_pospos_unique_inds,~,~] = unique(pospos);
[obj.coac_negneg_unique_inds,~,~] = unique(negneg);
[obj.coac_posneg_unique_inds,~,~] = unique(posneg);
[obj.coac_negpos_unique_inds,~,~] = unique(negpos);
obj.coac_pospos_repeating_inds = pospos == obj.coac_pospos_unique_inds';
obj.coac_negneg_repeating_inds = negneg == obj.coac_negneg_unique_inds';
obj.coac_posneg_repeating_inds = posneg == obj.coac_posneg_unique_inds';
obj.coac_negpos_repeating_inds = negpos == obj.coac_negpos_unique_inds';
end
%% Ordinal Feedback:
[obj.ord_data_unique_inds,~,~] = unique(obj.ord_data);
obj.ord_data_repeating_inds = obj.ord_data == obj.ord_data_unique_inds';
end

