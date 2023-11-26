## Personal Website for Orchid (powered by Hugo)

### Rendering Latex Equations

Add `math: true` to the page markdown header followed by embedding this javascript:

```javascript
<script type="text/javascript"
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_CHTML">
</script>
```

Inline math:
```
$ \varphi = \dfrac{1+\sqrt5}{2}= 1.618033988 $
```

Block math:

```
$$
\tag{1.1}
\sigma(t) = \cfrac{1}{1 + e^{-t}}
$$
```




