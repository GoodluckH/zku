pragma circom 2.0.0;
include "mimcsponge.circom";

/*This circuit template returns the root of a merkle tree given an array input.*/  

template Merkle (n) { 

    // Declaration of signals.  
    signal input leaves[n]; 
    signal output root;  

    var counter = 0;
    var k = n;
    var treeDepth;

    while (k > 0) {
        counter++;
        k >>= 1;
    }
    treeDepth = counter;

    component hashes[treeDepth];
    component leavesToHash[treeDepth];

    for (var i = 0; i < treeDepth; i++) {
        leavesToHash[i] = storeLeaves();
        leavesToHash[i].in[0] <== i == 0 ? leaves[0] : hashes[i - 1].hash;
        leavesToHash[i].in[1] <== leaves[i];

        hashes[i] = getHash();
        hashes[i].left <== leavesToHash[i].out[0];
        hashes[i].right <== leavesToHash[i].out[1];
    }


    root <== hashes[treeDepth - 1].hash;
}
// Use this to temporarily store two leaves for hashing purpose
template storeLeaves() {
    signal input in[2];
    signal output out[2];

    out[0] <== in[0];
    out[1] <== in[1]; 
}

// Helper template to get the hash of two leaves
template getHash() {
    signal input left;
    signal input right;
    signal output hash;

    component sponge = MiMCSponge(2, 220, 1);
    sponge.ins[0] <== left;
    sponge.ins[1] <== right;
    sponge.k <== 0;

    hash <== sponge.outs[0];
}

 component main{public [leaves]} = Merkle(8);
