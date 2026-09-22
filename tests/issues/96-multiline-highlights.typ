#import "../../codly.typ" as codly

#set page(width: 300pt, height: auto, margin: 5pt)

// #96: the requested `line: (8, 10)` form is rejected during element parsing.
#assert(
  catch(() => codly.highlight(line: (8, 10), start: 5, fill: red)) != none,
)

// The current workaround requires one span per source line.
#codly.new(
  ```f90
  do concurrent(l=1:ctx_dg%n_different_order, k=1:ctx_dg%n_different_order)
    n_dof_k = ctx_dg%n_dof_per_order(k)
    n_dof_l = ctx_dg%n_dof_per_order(l)

    face_phi_xi(k,l)%array = sum(ctx_dg%quadGL_face_phi_phi_w(k,l)%array, dim=3)

    do concurrent(jdim=1:2, kdim=1:2, iface=1:3, j=1:n_dof_l, i=1:n_dof_k)
      face_phi_xi_nCntau(k,l)%array(i,j,iface,kdim,jdim) = dot_product(&
        face_coeff_Cx(iface,:,kdim,jdim), &
        ctx_dg%quadGL_face_phi_phi_w(k,l)%array(i,j,:,iface))
    end do
  end do
  ```,
  highlights: (
    (line: 5, start: 3, fill: yellow),
    (line: 8, start: 5, fill: red),
    (line: 9, start: 0, fill: red),
    (line: 10, start: 0, fill: red),
  ),
)
