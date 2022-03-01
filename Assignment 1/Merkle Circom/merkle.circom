pragma circom 2.0.0;
include "mimcsponge.circom";

/*This circuit template checks that c is the multiplication of a and b.*/  

template Merkle (n) {  // n = 4

   // Declaration of signals.  
   signal input leaves[n];  // [1,2,3,4]
   signal output root;  

    var parent_size = n >> 1; // 2
    var childs[n];
    
    for (var i = 0; i < n; i++) {childs[i] = leaves[i];}
    
    var numOfComponents = 0;
    var totalLeaves = n >> 1;
    while (totalLeaves > 0){
         numOfComponents++; 
         totalLeaves >>= 1;
         }
    component c[numOfComponents];
    for (var i = 0; i < numOfComponents; i++) {c[i] = MiMCSponge(2, 220, 1);}

    while (n > 0) {//leveling up each loop
        var i = 0;
        var counter = 0;
        var parents[parent_size]; // [_]
        while (i < n) { // n = 2

            c[counter].ins[0] <== childs[i];
            c[counter].ins[1] <== childs[i + 1];
            c[counter].k <== i;
            parents[i >> 1] = c[counter].outs[0];

            
            parent_size >>= 1; // 1
            if (i == 0) {
                i = 2;
            } else {
                i *= 2;
            }
        }
        counter++;
        childs = parents; 
        n >>= 1; // 2
    }
    
     root <== childs[0];
}

 component main{public [leaves]} = Merkle(4);
