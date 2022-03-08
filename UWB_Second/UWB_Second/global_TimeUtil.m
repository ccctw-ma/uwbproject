
%global_TimeUtil

global anchor12RxTime;
global anchor13RxTime;
global anchor14RxTime;
global anchor12SeqNum;
global anchor13SeqNum;
global anchor14SeqNum;
global anchor31RxTime;
global anchor32RxTime;
global anchor34RxTime;
global anchor31SeqNum;
global anchor32SeqNum;
global anchor34SeqNum;
global haveNullOrDataCount;
global anchorRxTime;


anchor12RxTime = zeros(256,1);
anchor13RxTime = zeros(256,1);
anchor14RxTime = zeros(256,1);
anchor12SeqNum = 0;
anchor13SeqNum = 0;
anchor14SeqNum = 0;
anchor31RxTime = zeros(256,1);
anchor32RxTime = zeros(256,1);
anchor34RxTime = zeros(256,1);
anchor31SeqNum = 0;
anchor32SeqNum = 0;
anchor34SeqNum = 0;

haveNullOrDataCount = 0;
anchorRxTime = zeros(256,4);