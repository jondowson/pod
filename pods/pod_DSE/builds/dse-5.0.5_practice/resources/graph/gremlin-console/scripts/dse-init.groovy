import com.datastax.bdp.graph.api.query.Geo
import com.datastax.bdp.graph.api.query.Search
:remote connect tinkerpop.server conf/remote.yaml session-managed
:remote config timeout max
:remote console
