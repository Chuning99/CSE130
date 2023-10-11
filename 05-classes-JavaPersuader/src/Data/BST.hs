module Data.BST where 

import qualified Test.QuickCheck as QC
import qualified Data.List       as L

-------------------------------------------------------------------------------
-- | BST data type 
-------------------------------------------------------------------------------

data BST a
  = Leaf                      -- ^ empty tree
  | Node a (BST a) (BST a)    -- ^ node with left and right subtrees
  deriving (Show)

-- | Binary-Search Ordering Invariant

isOrdered :: (Ord a) => BST a -> Bool
isOrdered Leaf         = True 
isOrdered (Node e l r) = forall l (\x -> x < e) -- all elts in `l` are less    than `e`
                      && forall r (\x -> e < x) -- all elts in `r` are greater than `e` 
                      && isOrdered l            -- left subtree `isOrdered`
                      && isOrdered r            -- right subtree `isOrdered` 

forall :: BST a -> (a -> Bool) -> Bool
forall Leaf         _ = True
forall (Node e l r) p = p e && forall l p && forall r p

-------------------------------------------------------------------------------
-- | The empty BST
-------------------------------------------------------------------------------
empty :: BST a
empty = Leaf 


-------------------------------------------------------------------------------
-- | Build a tree from a list
-------------------------------------------------------------------------------
build :: (Ord a) => [a] -> BST a
build xs = case reverse xs of
  (a:as) -> add a (build as)
  [] -> Leaf
  
-------------------------------------------------------------------------------
-- | Check membership in BST
-------------------------------------------------------------------------------
contains :: (Ord a) => a -> BST a -> Bool
contains x t = case t of
  Node root left right -> if root == x then True else if (root < x) then (contains x right) else (contains x left)
  Leaf -> False

t2 :: BST Int
t2 = Node 5 Leaf (Node 20 (Node 10 Leaf Leaf) (Node 30 Leaf Leaf))


-------------------------------------------------------------------------------
-- | In-order traversal (fold)
-------------------------------------------------------------------------------
fold :: (b -> a -> b) ->b -> BST a -> b
fold f b t = case t of
   Leaf -> b
   Node root left right -> fold f (f (fold f b left) root ) right
    


toList :: BST a -> [a]
toList = reverse . fold (\xs x -> x:xs) []

toString :: (Show a) => BST a -> String
toString t = "build " ++ show (toList t) 


-------------------------------------------------------------------------------
-- | Adding an element
-------------------------------------------------------------------------------
add :: (Ord a) => a -> BST a -> BST a
add x t = case t of
  Node root left right -> if contains x t then t else if root < x then Node root left (add x right) else Node root (add x left) right 
  Leaf -> Node x Leaf Leaf
---------------------------------
minize :: (Ord a) => [a] -> (a, BST a)
minize (a: as) = (a, build as)

-------------------------------------------------------------------------------
-- | Removing the minumum element
-------------------------------------------------------------------------------
removeMin :: (Ord a) => BST a -> (a, BST a)
removeMin t =  minize (toList t)

-------------------------------------------------------------------------------
-- | Removing an element
-------------------------------------------------------------------------------
remove :: (Ord a) => a -> BST a -> BST a
remove x t = case t of
  Node root left right -> if x /= a then (add a (remove x b)) else b
  Leaf -> t
  where
    (a, b) = removeMin t

-------------------------------------------------------------------------------
-- | QuickCheck Properties
-------------------------------------------------------------------------------

--  Holds after `build`
prop_build :: [Int] -> Bool
prop_build xs = isOrdered (build xs)

--  Holds after `contains` and `build`
prop_contains_elt :: Int -> [Int] -> Bool
prop_contains_elt x xs = (x `elem` xs) == (contains x (build xs))

--  Holds after `contains` and `fold`
prop_contains_elts :: BST Int -> Bool 
prop_contains_elts t = and [ contains x t | x <- toList t ] 

-- Holds after `add`
prop_add_elt :: Int -> BST Int -> Bool 
prop_add_elt elt t = contains elt (add elt t) 
  
-- Holds after `add`
prop_add_elts_old :: Int -> BST Int -> Bool 
prop_add_elts_old elt t = forall t (\x -> contains x t') 
  where 
    t'                  = add elt t   

-- Holds after `add`
prop_add_isOrd :: Int -> BST Int -> Bool
prop_add_isOrd elt t = isOrdered (add elt t)

-- Holds after `add`: Fix this property
prop_multiset :: [Int] -> Bool 

removeHelper :: [Int] -> [Int] -> [Int]
removeHelper x t = case t of
  [] -> x
  (a:as)-> removeHelper one two
    where 
      one = if elem a x == False then [a] ++ x else x
      two = as

removeMultset :: [Int] -> [Int]
removeMultset list = reverse (removeHelper [] list)
    
--prop_multiset xs = toList (build xs) == L.sort xs   -- <<<< TBD: you need to fix this property
prop_multiset xs = toList (build xs) == L.sort (removeMultset xs) -- <<<< TBD: you need to fix this property


-- Holds after `removeMin`
prop_remove_min :: BST Int -> Bool
prop_remove_min Leaf = True
prop_remove_min t    = contains x t && forall t' (\y -> x < y) 
  where 
    (x, t')          = removeMin t

-- Holds after `remove`
prop_remove :: Int -> BST Int -> Bool 
prop_remove elt t = not (contains elt t') 
  where 
    t'            = remove elt t 

-- Holds after `remove`
prop_remove_old :: Int -> BST Int -> Bool 
prop_remove_old elt t = forall t (\x -> x == elt || contains x t') 
  where 
    t'                = remove elt t 

-- Holds after `remove`
prop_remove_isOrd :: Int -> BST Int -> Bool
prop_remove_isOrd elt t = isOrdered (remove elt t)

-------------------------------------------------------------------------------
-- | QuickCheck Instance
-------------------------------------------------------------------------------
quickCheck :: (QC.Testable prop) => prop -> IO ()
quickCheck = QC.quickCheck

instance (Ord a, QC.Arbitrary a) => QC.Arbitrary (BST a) where
  arbitrary = build <$> QC.arbitrary
